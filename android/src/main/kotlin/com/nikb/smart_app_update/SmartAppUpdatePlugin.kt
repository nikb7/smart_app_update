package com.nikb.smart_app_update

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.ActivityResult
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener // Required for onActivityResult


class SmartAppUpdatePlugin : FlutterPlugin, UpdateHostApi, ActivityAware, ActivityResultListener {
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var appUpdateManager: AppUpdateManager
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    // For flexible updates
    private var flexibleUpdateListener: InstallStateUpdatedListener? = null
    private var flutterApi: UpdateFlutterApi? = null


    // Request codes for update flows
    companion object {
        private const val REQUEST_CODE_IMMEDIATE_UPDATE = 17362
        private const val REQUEST_CODE_FLEXIBLE_UPDATE = 17363
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = binding
        this.context = binding.applicationContext
        appUpdateManager = AppUpdateManagerFactory.create(context)
        UpdateHostApi.setUp(binding.binaryMessenger, this)
        flutterApi = UpdateFlutterApi(binding.binaryMessenger) // Initialize Flutter API
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        UpdateHostApi.setUp(binding.binaryMessenger, null)
        unregisterFlexibleUpdateListener()
        this.flutterPluginBinding = null
        flutterApi = null
    }

    // --- UpdateHostApi Implementation ---

    override fun isUpdateAvailable(callback: (Result<Boolean>) -> Unit) {
        appUpdateManager.appUpdateInfo.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val playUpdateInfo = task.result
                val updateAvailable =
                    playUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE
                callback(Result.success(updateAvailable))

            } else {
                callback(
                    Result.failure(
                        task.exception ?: Exception("Unknown error checking for update")
                    )
                )
            }
        }
    }

    override fun startImmediateUpdate(callback: (Result<Boolean>) -> Unit) {
        val currentActivity = activity
        if (currentActivity == null) {
            callback(Result.failure(Exception("Activity not available to start immediate update.")))
            return
        }

        appUpdateManager.appUpdateInfo.addOnSuccessListener { playUpdateInfo ->
            if (playUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                playUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)
            ) {
                val appUpdateOptions = AppUpdateOptions.newBuilder(AppUpdateType.IMMEDIATE).build()
                try {
                    appUpdateManager.startUpdateFlowForResult(
                        playUpdateInfo,
                        currentActivity,
                        appUpdateOptions,
                        REQUEST_CODE_IMMEDIATE_UPDATE
                    )
                    // The actual result comes in onActivityResult.
                    // Here, we signal that the flow was started.
                    // Pigeon expects a boolean, true if started.
                    callback(Result.success(true))
                } catch (e: Exception) {
                    callback(Result.failure(e))
                }
            } else {
                callback(Result.success(false)) // Or failure if "not available" is an error state for the caller
            }
        }.addOnFailureListener { e ->
            callback(Result.failure(e))
        }
    }

    override fun startFlexibleUpdate(callback: (Result<Boolean>) -> Unit) {
        val currentActivity = activity
        if (currentActivity == null) {
            callback(Result.failure(Exception("Activity not available to start flexible update.")))
            return
        }

        appUpdateManager.appUpdateInfo.addOnSuccessListener { playUpdateInfo ->
            if (playUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE &&
                playUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)
            ) {
                registerFlexibleUpdateListener()
                val appUpdateOptions = AppUpdateOptions.newBuilder(AppUpdateType.FLEXIBLE).build()
                try {
                    appUpdateManager.startUpdateFlowForResult(
                        playUpdateInfo,
                        currentActivity,
                        appUpdateOptions,
                        REQUEST_CODE_FLEXIBLE_UPDATE
                    )
                    callback(Result.success(true))
                } catch (e: Exception) {
                    unregisterFlexibleUpdateListener() // Clean up listener on error
                    callback(Result.failure(e))
                }
            } else {
                callback(Result.success(false))
            }
        }.addOnFailureListener { e ->
            callback(Result.failure(e))
        }
    }


    private fun registerFlexibleUpdateListener() {
        if (flexibleUpdateListener != null) return // Already registered

        flexibleUpdateListener = InstallStateUpdatedListener { state ->
            when (state.installStatus()) {
                InstallStatus.DOWNLOADING -> {
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            bytesDownloaded = state.bytesDownloaded(),
                            totalBytes = state.totalBytesToDownload(),
                            status = UpdateStatus.DOWNLOADING
                        )
                    ) {}
                }

                InstallStatus.DOWNLOADED -> {
                    val totalBytes = state.totalBytesToDownload()
                    // Notify Flutter that download is complete and user can trigger install
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            bytesDownloaded = totalBytes,
                            totalBytes = totalBytes,
                            status = UpdateStatus.DOWNLOADED
                        )
                    ) {}
                }

                InstallStatus.INSTALLING -> {
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            status = UpdateStatus.DOWNLOADED
                        )
                    ) {}
                }

                InstallStatus.PENDING -> {
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            status = UpdateStatus.CHECKING
                        )
                    ) {}
                }

                InstallStatus.INSTALLED -> {
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            status = UpdateStatus.INSTALLED
                        )
                    ) {}
                    unregisterFlexibleUpdateListener()
                }
                InstallStatus.CANCELED -> {
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            status = UpdateStatus.CANCELED
                        )
                    ) {}
                    unregisterFlexibleUpdateListener()
                }
                else -> {
                    flutterApi?.onUpdateProgress(
                        ProgressInfo(
                            status = UpdateStatus.FAILED
                        )
                    ) {}
                    unregisterFlexibleUpdateListener()
                }
            }
        }
        appUpdateManager.registerListener(flexibleUpdateListener!!)
    }

    private fun unregisterFlexibleUpdateListener() {
        flexibleUpdateListener?.let {
            appUpdateManager.unregisterListener(it)
            flexibleUpdateListener = null
        }
    }


    override fun completeFlexibleUpdate(callback: (Result<Boolean>) -> Unit) {
        appUpdateManager.completeUpdate().addOnSuccessListener {
            // App will restart. This callback might not even be hit if restart is immediate.
            callback(Result.success(true))
        }.addOnFailureListener { e ->
            callback(Result.failure(e))
        }
    }

    // --- ActivityAware Implementation ---
    private var activityBinding: ActivityPluginBinding? = null
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this) // Register for onActivityResult
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        unregisterFlexibleUpdateListener() // Clean up listener if activity is destroyed
    }

    // --- ActivityResultListener Implementation ---
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            REQUEST_CODE_IMMEDIATE_UPDATE -> {
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        // Successfully installed
                        flutterApi?.onUpdateProgress(
                            ProgressInfo(
                                status = UpdateStatus.INSTALLED
                            )
                        ) {}
                    }

                    Activity.RESULT_CANCELED -> {
                        // User canceled the update
                        flutterApi?.onUpdateProgress(
                            ProgressInfo(
                                status = UpdateStatus.CANCELED
                            )
                        ) {}
                    }

                    ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> {
                        // Update failed or was canceled by Play Store
                        flutterApi?.onUpdateProgress(
                            ProgressInfo(
                                status = UpdateStatus.FAILED
                            )
                        ) {}
                    }
                }
                return true
            }

            REQUEST_CODE_FLEXIBLE_UPDATE -> {
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        // This means the user accepted the flexible update prompt.
                        // The actual download/install is handled by the listener.
                        // You might not need to do much here, or just log it.
                        flutterApi?.onUpdateProgress(
                            ProgressInfo(
                                status = UpdateStatus.DOWNLOADING
                            )
                        ) {}
                    }

                    Activity.RESULT_CANCELED -> {
                        flutterApi?.onUpdateProgress(
                            ProgressInfo(
                                status = UpdateStatus.CANCELED
                            )
                        ) {}
                        unregisterFlexibleUpdateListener() // User declined, stop listening for this attempt
                    }

                    ActivityResult.RESULT_IN_APP_UPDATE_FAILED -> {
                        flutterApi?.onUpdateProgress(
                            ProgressInfo(
                                status = UpdateStatus.FAILED
                            )
                        ) {}
                        unregisterFlexibleUpdateListener()
                    }
                }
                return true
            }
        }
        return false
    }
}
