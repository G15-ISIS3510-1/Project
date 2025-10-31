package com.example.kotlinapp.data.api

object BackendApis {
    val vehicles: VehiclesApiService by lazy { ApiClient.create(VehiclesApiService::class.java) }
    val pricing: PricingApiService  by lazy { ApiClient.create(PricingApiService::class.java) }
    val payments: PaymentsApiService by lazy { ApiClient.create(PaymentsApiService::class.java) }
    val conversations: ConversationsApiService by lazy { ApiClient.create(ConversationsApiService::class.java) }
    val messages: MessagesApiService by lazy { ApiClient.create(MessagesApiService::class.java) }

}