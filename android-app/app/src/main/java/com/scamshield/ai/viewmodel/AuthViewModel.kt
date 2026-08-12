package com.scamshield.ai.viewmodel

import android.app.Application
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.scamshield.ai.repository.AuthRepository
import com.scamshield.ai.util.SessionManager
import com.scamshield.ai.model.GenericResponse
import com.google.gson.Gson
import kotlinx.coroutines.launch

class AuthViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = AuthRepository(application)
    private val sessionManager = SessionManager(application)
    private val gson = Gson()

    private val _isLoggedIn = mutableStateOf(sessionManager.isLoggedIn())
    val isLoggedIn: State<Boolean> = _isLoggedIn

    val userName: String get() = sessionManager.getUserName() ?: "User"
    val userEmail: String get() = sessionManager.getUserEmail() ?: ""
    val isAdmin: Boolean get() = sessionManager.isAdmin()

    private val _isLoading = mutableStateOf(false)
    val isLoading: State<Boolean> = _isLoading

    private val _error = mutableStateOf<String?>(null)
    val error: State<String?> = _error

    fun login(email: String, pass: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = repository.login(email, pass)
                if (response.isSuccessful) {
                    val body = response.body()
                    if (body?.status == "success" && body.token != null) {
                        sessionManager.saveToken(body.token)
                        body.user?.let { 
                            sessionManager.saveUser(it.id, it.name, it.email, it.isAdmin) 
                        }
                        _isLoggedIn.value = true
                    } else {
                        _error.value = body?.message ?: "Login failed"
                    }
                } else {
                    _error.value = parseError(response)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    private fun <T> parseError(response: retrofit2.Response<T>): String {
        return try {
            val errorBody = response.errorBody()?.string()
            val errorRes = gson.fromJson(errorBody, GenericResponse::class.java)
            errorRes.message ?: "Server error: ${response.code()}"
        } catch (e: Exception) {
            "Server error: ${response.code()}"
        }
    }

    fun register(name: String, email: String, pass: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = repository.register(name, email, pass)
                if (response.isSuccessful) {
                    val body = response.body()
                    if (body?.status == "success") {
                        // After register, we could auto-login or just send to login screen
                        _error.value = "Registered successfully. Please login."
                    } else {
                        _error.value = body?.message ?: "Registration failed"
                    }
                } else {
                    _error.value = parseError(response)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun logout() {
        sessionManager.logout()
        _isLoggedIn.value = false
    }

    fun forgotPassword(email: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val response = repository.forgotPassword(email)
                if (response.isSuccessful) onSuccess()
                else _error.value = parseError(response)
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun resetPassword(email: String, otp: String, pass: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val response = repository.resetPassword(email, otp, pass)
                if (response.isSuccessful) onSuccess()
                else _error.value = parseError(response)
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
}
