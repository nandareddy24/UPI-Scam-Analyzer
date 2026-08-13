package com.scamshield.ai.repository

import android.content.Context
import com.scamshield.ai.api.RetrofitClient

class AuthRepository(context: Context) {
    private val api = RetrofitClient.getApiService(context)

    suspend fun login(email: String, pass: String) = api.login(mapOf("email" to email, "password" to pass))
    
    suspend fun register(name: String, email: String, pass: String) = 
        api.register(mapOf("name" to name, "email" to email, "password" to pass))

    suspend fun verifyRegistration(email: String, otp: String) = 
        api.verifyRegistration(mapOf("email" to email, "otp" to otp))
    
    suspend fun getProfile() = api.getProfile()

    suspend fun forgotPassword(email: String) = api.forgotPassword(mapOf("email" to email))

    suspend fun resetPassword(email: String, otp: String, pass: String) = 
        api.resetPassword(mapOf("email" to email, "otp" to otp, "password" to pass))

    suspend fun logout() = try { api.logout() } catch (e: Exception) { null }

    suspend fun getAdminBlacklist() = api.getAdminBlacklist()
    suspend fun addAdminBlacklist(data: String, type: String, reason: String) = 
        api.addAdminBlacklist(com.scamshield.ai.model.AddBlacklistRequest(data, type, reason))
    suspend fun deleteAdminBlacklist(id: Int) = api.deleteAdminBlacklist(id)
    suspend fun getAdminReports() = api.getAdminReports()
    suspend fun approveAdminReport(id: Int) = api.approveAdminReport(id)
    suspend fun rejectAdminReport(id: Int) = api.rejectAdminReport(id)
}
