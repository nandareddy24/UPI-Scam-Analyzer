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
        val fallback = when (response.code()) {
            401 -> "Invalid credentials or unauthorized access"
            403 -> "Not authorized"
            404 -> "Resource not found"
            500 -> "Server error"
            503 -> "Service unavailable"
            else -> "Server error: ${response.code()}"
        }
        return try {
            val errorBody = response.errorBody()?.string()
            val errorRes = gson.fromJson(errorBody, GenericResponse::class.java)
            errorRes.message ?: fallback
        } catch (e: Exception) {
            fallback
        }
    }

    fun register(name: String, email: String, pass: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = repository.register(name, email, pass)
                if (response.isSuccessful) {
                    onSuccess()
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

    fun verifyRegistration(email: String, otp: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                val response = repository.verifyRegistration(email, otp)
                if (response.isSuccessful) {
                    onSuccess()
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
        viewModelScope.launch {
            try {
                repository.logout()
            } catch (e: Exception) {
                // Ignore network failure on logout
            } finally {
                sessionManager.logout()
                _isLoggedIn.value = false
            }
        }
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

    private val _adminReports = mutableStateOf<List<com.scamshield.ai.model.AdminReportItem>>(emptyList())
    val adminReports: State<List<com.scamshield.ai.model.AdminReportItem>> = _adminReports

    private val _adminBlacklist = mutableStateOf<List<com.scamshield.ai.model.BlacklistItem>>(emptyList())
    val adminBlacklist: State<List<com.scamshield.ai.model.BlacklistItem>> = _adminBlacklist

    fun fetchAdminReports() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val resp = repository.getAdminReports()
                if (resp.isSuccessful) {
                    _adminReports.value = resp.body() ?: emptyList()
                } else {
                    _error.value = parseError(resp)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun fetchAdminBlacklist() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val resp = repository.getAdminBlacklist()
                if (resp.isSuccessful) {
                    _adminBlacklist.value = resp.body() ?: emptyList()
                } else {
                    _error.value = parseError(resp)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun approveReport(id: Int) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val resp = repository.approveAdminReport(id)
                if (resp.isSuccessful) {
                    fetchAdminReports()
                    fetchAdminBlacklist()
                } else {
                    _error.value = parseError(resp)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun rejectReport(id: Int) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val resp = repository.rejectAdminReport(id)
                if (resp.isSuccessful) {
                    fetchAdminReports()
                } else {
                    _error.value = parseError(resp)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun addBlacklist(data: String, type: String, reason: String) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val resp = repository.addAdminBlacklist(data, type, reason)
                if (resp.isSuccessful) {
                    fetchAdminBlacklist()
                } else {
                    _error.value = parseError(resp)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun deleteBlacklist(id: Int) {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val resp = repository.deleteAdminBlacklist(id)
                if (resp.isSuccessful) {
                    fetchAdminBlacklist()
                } else {
                    _error.value = parseError(resp)
                }
            } catch (e: Exception) {
                _error.value = "Connection error: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }
}
