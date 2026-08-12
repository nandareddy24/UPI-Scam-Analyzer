package com.scamshield.ai.repository

import android.content.Context
import com.scamshield.ai.api.RetrofitClient
import com.scamshield.ai.model.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File

class ScamRepository(context: Context) {
    private val api = RetrofitClient.getApiService(context)

    suspend fun scanUpi(upi: String) = api.scanUpi(ScanRequest(upi = upi))
    suspend fun scanPhone(phone: String) = api.scanPhone(ScanRequest(phone = phone))
    suspend fun scanSms(sms: String) = api.scanSms(ScanRequest(sms = sms))
    suspend fun scanUrl(url: String) = api.scanUrl(ScanRequest(url = url))

    suspend fun scanOcr(imageFile: File): retrofit2.Response<ScanResponse> {
        val requestFile = imageFile.asRequestBody("image/*".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("screenshot", imageFile.name, requestFile)
        return api.scanOcr(body)
    }

    suspend fun scanQr(imageFile: File): retrofit2.Response<ScanResponse> {
        val requestFile = imageFile.asRequestBody("image/*".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("qr_image", imageFile.name, requestFile)
        return api.scanQr(body)
    }

    suspend fun getHistory(): retrofit2.Response<ScamShieldHistoryResponse> = api.getHistory()
    
    suspend fun reportScam(type: String, data: String, reason: String, proof: String?) = 
        api.reportScam(ReportRequest(type, data, reason, proof))
}
