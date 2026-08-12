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
}
