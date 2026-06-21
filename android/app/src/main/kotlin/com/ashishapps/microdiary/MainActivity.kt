package com.ashishapps.microdiary

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets

class MainActivity : FlutterActivity() {
    private val channelName = "macro_diary/backup_files"
    private val exportRequestCode = 4101
    private val importRequestCode = 4102

    private var pendingResult: MethodChannel.Result? = null
    private var pendingExportContents: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "exportBackup" -> exportBackup(call, result)
                    "importBackup" -> importBackup(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun exportBackup(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "Another backup file operation is running.", null)
            return
        }

        val fileName = call.argument<String>("fileName") ?: "macro_diary_backup.json"
        val mimeType = call.argument<String>("mimeType") ?: "application/json"
        val contents = call.argument<String>("contents") ?: ""

        pendingResult = result
        pendingExportContents = contents

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        startActivityForResult(intent, exportRequestCode)
    }

    private fun importBackup(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "Another backup file operation is running.", null)
            return
        }

        val mimeType = call.argument<String>("mimeType") ?: "application/json"

        pendingResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivityForResult(intent, importRequestCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        when (requestCode) {
            exportRequestCode -> finishExport(resultCode, data?.data)
            importRequestCode -> finishImport(resultCode, data?.data)
        }
    }

    private fun finishExport(resultCode: Int, uri: Uri?) {
        val result = pendingResult ?: return
        val contents = pendingExportContents ?: ""
        clearPendingOperation()

        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }

        try {
            contentResolver.openOutputStream(uri)?.use { stream ->
                stream.write(contents.toByteArray(StandardCharsets.UTF_8))
            } ?: throw IllegalStateException("Could not open backup destination.")
            result.success(uri.toString())
        } catch (error: Exception) {
            result.error("export_failed", error.message, null)
        }
    }

    private fun finishImport(resultCode: Int, uri: Uri?) {
        val result = pendingResult ?: return
        clearPendingOperation()

        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }

        try {
            val contents = contentResolver.openInputStream(uri)?.use { stream ->
                String(stream.readBytes(), StandardCharsets.UTF_8)
            } ?: throw IllegalStateException("Could not open backup file.")
            result.success(contents)
        } catch (error: Exception) {
            result.error("import_failed", error.message, null)
        }
    }

    private fun clearPendingOperation() {
        pendingResult = null
        pendingExportContents = null
    }
}
