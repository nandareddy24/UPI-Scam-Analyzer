package com.scamshield.ai.api

import android.content.Context
import com.scamshield.ai.util.SessionManager
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object RetrofitClient {
    private const val BASE_URL = "http://192.168.31.243:3000/" // Default for local dev, should be changed to production URL

    fun getApiService(context: Context): ApiService {
        val sessionManager = SessionManager(context)
        
        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        val client = OkHttpClient.Builder()
            .addInterceptor(logging)
            .addInterceptor { chain ->
                val request = chain.request().newBuilder()
                sessionManager.getToken()?.let {
                    request.addHeader("Authorization", "Bearer $it")
                }
                chain.proceed(request.build())
            }
            .build()

        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .client(client)
            .build()
            .create(ApiService::class.java)
    }
}
