package com.scamshield.ai.api

import com.scamshield.ai.model.*
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    @POST("api/v1/auth/register")
    suspend fun register(@Body request: Map<String, String>): Response<GenericResponse>

    @POST("api/v1/auth/verify-registration")
    suspend fun verifyRegistration(@Body request: Map<String, String>): Response<GenericResponse>

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
    @POST("api/v1/scan/image")
    suspend fun scanOcr(@Part screenshot: MultipartBody.Part): Response<ScanResponse>

    @Multipart
    @POST("api/v1/scan/qr")
    suspend fun scanQr(@Part qr_image: MultipartBody.Part): Response<ScanResponse>

    @GET("api/v1/scans/history")
    suspend fun getHistory(): Response<ScamShieldHistoryResponse>

    @POST("api/v1/reports")
    suspend fun reportScam(@Body request: ReportRequest): Response<GenericResponse>

    @POST("api/v1/auth/logout")
    suspend fun logout(): Response<GenericResponse>

    @GET("api/v1/admin/blacklist")
    suspend fun getAdminBlacklist(): Response<List<BlacklistItem>>

    @POST("api/v1/admin/blacklist")
    suspend fun addAdminBlacklist(@Body request: AddBlacklistRequest): Response<GenericResponse>

    @DELETE("api/v1/admin/blacklist/{id}")
    suspend fun deleteAdminBlacklist(@Path("id") id: Int): Response<GenericResponse>

    @GET("api/v1/admin/reports")
    suspend fun getAdminReports(): Response<List<AdminReportItem>>

    @POST("api/v1/admin/reports/{id}/approve")
    suspend fun approveAdminReport(@Path("id") id: Int): Response<GenericResponse>

    @POST("api/v1/admin/reports/{id}/reject")
    suspend fun rejectAdminReport(@Path("id") id: Int): Response<GenericResponse>
}
