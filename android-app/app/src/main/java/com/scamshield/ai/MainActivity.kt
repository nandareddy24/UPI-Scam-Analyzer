package com.scamshield.ai

import android.Manifest
import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.webkit.*
import android.widget.ProgressBar
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import java.io.File
import java.io.IOException

class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var progressBar: ProgressBar
    private lateinit var swipeRefreshLayout: SwipeRefreshLayout

    private var fileUploadCallback: ValueCallback<Array<Uri>>? = null
    private var cameraImageUri: Uri? = null

    private var appUrl: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webView)
        progressBar = findViewById(R.id.progressBar)
        swipeRefreshLayout = findViewById(R.id.swipeRefreshLayout)

        appUrl = resolveTargetUrl()

        setupCookieManager()
        setupWebView()
        setupSwipeRefresh()

        checkAndRequestPermissions()

        if (savedInstanceState != null) {
            webView.restoreState(savedInstanceState)
        } else {
            webView.loadUrl(appUrl)
        }
    }

    /**
     * Determines whether the app is running on Android Emulator or a Physical Phone.
     * - Emulator: Uses http://10.0.2.2:3000/mobile_app
     * - Physical Phone: Uses server_url string from resources (http://<YOUR_PC_IP>:3000/mobile_app)
     */
    private fun resolveTargetUrl(): String {
        val configuredUrl = getString(R.string.server_url)
        val emulatorUrl = getString(R.string.emulator_server_url)

        return if (isEmulator()) {
            emulatorUrl
        } else {
            configuredUrl
        }
    }

    private fun isEmulator(): Boolean {
        return (Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("google_sdk")
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")))
    }

    private fun setupCookieManager() {
        val cookieManager = CookieManager.getInstance()
        cookieManager.setAcceptCookie(true)
        cookieManager.setAcceptThirdPartyCookies(webView, true)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView() {
        with(webView.settings) {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            allowFileAccess = true
            allowContentAccess = true
            loadWithOverviewMode = true
            useWideViewPort = true
            builtInZoomControls = false
            displayZoomControls = false
            mediaPlaybackRequiresUserGesture = false
            mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            userAgentString = "$userAgentString ScamShieldAndroid/1.0"
        }

        webView.addJavascriptInterface(WebAppInterface(), "ScamShieldNative")

        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                progressBar.visibility = View.VISIBLE
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                progressBar.visibility = View.GONE
                swipeRefreshLayout.isRefreshing = false
                CookieManager.getInstance().flush()
            }

            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                if (request?.isForMainFrame == true) {
                    progressBar.visibility = View.GONE
                    swipeRefreshLayout.isRefreshing = false

                    val offlineHtml = """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <style>
                                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0f172a; color: white; padding: 24px 16px; margin: 0; }
                                .card { background: #1e293b; border-radius: 20px; padding: 28px 20px; border: 1px solid #334155; text-align: center; max-width: 480px; margin: 20px auto; shadow: 0 10px 25px rgba(0,0,0,0.5); }
                                h2 { color: #f8fafc; font-size: 22px; margin-top: 0; margin-bottom: 12px; }
                                p { color: #94a3b8; font-size: 14px; line-height: 1.5; margin: 8px 0; }
                                .url-box { background: #0f172a; border: 1px solid #334155; padding: 10px 14px; border-radius: 10px; font-family: monospace; color: #34d399; font-size: 13px; word-break: break-all; margin: 14px 0; }
                                .checklist { text-align: left; background: #0f172a; padding: 14px 18px; border-radius: 12px; margin: 16px 0; font-size: 13px; color: #cbd5e1; border: 1px solid #334155; }
                                .checklist li { margin-bottom: 8px; }
                                button { background: #10b981; color: white; border: none; padding: 14px 28px; border-radius: 12px; font-weight: bold; font-size: 15px; width: 100%; cursor: pointer; }
                                button:active { background: #059669; }
                            </style>
                        </head>
                        <body>
                            <div class="card">
                                <h2>🛡️ ScamShield Offline</h2>
                                <p>Unable to connect to the ScamShield server at:</p>
                                <div class="url-box">$appUrl</div>
                                <div class="checklist">
                                    <strong>Troubleshooting Checklist:</strong>
                                    <ol style="padding-left: 20px; margin-top: 8px; margin-bottom: 0;">
                                        <li>Is Flask running on host? (<code>python app.py</code>)</li>
                                        <li>Are phone and PC on the <strong>same Wi-Fi network</strong>?</li>
                                        <li>Did you replace <code>YOUR_PC_IP</code> in <code>strings.xml</code> with your PC's IP?</li>
                                        <li>Is port 3000 allowed in Windows Firewall?</li>
                                    </ol>
                                </div>
                                <button onclick="location.reload()">🔄 Retry Connection</button>
                            </div>
                        </body>
                        </html>
                    """.trimIndent()
                    webView.loadDataWithBaseURL(null, offlineHtml, "text/html", "UTF-8", null)
                }
            }
        }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                if (newProgress == 100) {
                    progressBar.visibility = View.GONE
                } else {
                    progressBar.visibility = View.VISIBLE
                    progressBar.progress = newProgress
                }
            }

            override fun onShowFileChooser(
                webView: WebView?,
                filePathCallback: ValueCallback<Array<Uri>>?,
                fileChooserParams: FileChooserParams?
            ): Boolean {
                fileUploadCallback?.onReceiveValue(null)
                fileUploadCallback = filePathCallback

                val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                try {
                    val photoFile = createTempImageFile()
                    cameraImageUri = FileProvider.getUriForFile(
                        this@MainActivity,
                        "com.scamshield.ai.fileprovider",
                        photoFile
                    )
                    takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, cameraImageUri)
                } catch (e: Exception) {
                    cameraImageUri = null
                }

                val contentSelectionIntent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "image/*"
                }

                val intentArray: Array<Intent> = if (cameraImageUri != null) {
                    arrayOf(takePictureIntent)
                } else {
                    emptyArray()
                }

                val chooserIntent = Intent(Intent.ACTION_CHOOSER).apply {
                    putExtra(Intent.EXTRA_INTENT, contentSelectionIntent)
                    putExtra(Intent.EXTRA_TITLE, "Select QR Code or Screenshot")
                    putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray)
                }

                fileChooserLauncher.launch(chooserIntent)
                return true
            }
        }
    }

    private val fileChooserLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (fileUploadCallback == null) return@registerForActivityResult

        var results: Array<Uri>? = null
        if (result.resultCode == RESULT_OK) {
            val intent = result.data
            if (intent != null && intent.data != null) {
                results = arrayOf(intent.data!!)
            } else if (cameraImageUri != null) {
                results = arrayOf(cameraImageUri!!)
            }
        }
        fileUploadCallback?.onReceiveValue(results)
        fileUploadCallback = null
    }

    private fun setupSwipeRefresh() {
        swipeRefreshLayout.setColorSchemeResources(R.color.accent)
        swipeRefreshLayout.setProgressBackgroundColorSchemeResource(R.color.surface_dark)
        swipeRefreshLayout.setOnRefreshListener {
            webView.reload()
        }
    }

    private fun checkAndRequestPermissions() {
        val permissions = mutableListOf(Manifest.permission.CAMERA)
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
        } else {
            permissions.add(Manifest.permission.READ_MEDIA_IMAGES)
        }

        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missingPermissions.isNotEmpty()) {
            permissionLauncher.launch(missingPermissions.toTypedArray())
        }
    }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val cameraGranted = permissions[Manifest.permission.CAMERA] ?: false
        if (!cameraGranted) {
            Toast.makeText(this, "Camera permission recommended for QR code scanning", Toast.LENGTH_SHORT).show()
        }
    }

    @Throws(IOException::class)
    private fun createTempImageFile(): File {
        val timeStamp = System.currentTimeMillis()
        val storageDir = cacheDir
        return File.createTempFile("SCAN_${timeStamp}_", ".jpg", storageDir)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        webView.saveState(outState)
    }

    inner class WebAppInterface {
        @JavascriptInterface
        fun showNativeToast(message: String) {
            Toast.makeText(this@MainActivity, message, Toast.LENGTH_SHORT).show()
        }

        @JavascriptInterface
        fun getAppVersion(): String {
            return "1.0.0-android"
        }
    }
}
