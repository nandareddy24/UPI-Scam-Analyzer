package com.scamshield.ai.api

import com.scamshield.ai.model.*
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    @POST("api/v1/auth/register")
    suspend fun register(@Body request: Map<String, String>): Response<RegisterResponse>

    @POST("api/v1/auth/login")
    suspend fun login(@Body request: Map<String, String>): Response<LoginResponse>

    @GET("api/v1/auth/me")
    suspend fun getProfile(): Response<LoginResponse>

    @POST("api/v1/auth/forgot-password")
    suspend fun forgotPassword(@Body request: Map<String, String>): Response<GenericResponse>

    @POST("api/v1/auth/reset-password")
    suspend fun resetPassword(@Body request: Map<String, String>): Response<GenericResponse>

    @POST("api/v1/scan/upi")
    suspend fun scanUpi(@Body request: ScanRequest): Response<ScanResponse>

    @POST("api/v1/scan/phone")
    suspend fun scanPhone(@Body request: ScanRequest): Response<ScanResponse>

    @POST("api/v1/scan/sms")
    suspend fun scanSms(@Body request: ScanRequest): Response<ScanResponse>

    @POST("api/v1/scan/url")
    suspend fun scanUrl(@Body request: ScanRequest): Response<ScanResponse>

    @Multipart
    @POST("scan_ocr")
    suspend fun scanOcr(@Part screenshot: MultipartBody.Part): Response<ScanResponse>

    @Multipart
    @POST("scan_qr")
    suspend fun scanQr(@Part qr_image: MultipartBody.Part): Response<ScanResponse>

    @GET("api/v1/mobile/history")
    suspend fun getHistory(): Response<List<HistoryItem>>

    @POST("report_scam")
    suspend fun reportScam(@Body request: ReportRequest): Response<GenericResponse>
}
