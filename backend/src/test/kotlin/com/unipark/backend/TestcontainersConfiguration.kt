package com.unipark.backend

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.context.annotation.Bean
import org.testcontainers.containers.GenericContainer
import org.testcontainers.containers.PostgreSQLContainer
import org.testcontainers.utility.DockerImageName

@TestConfiguration(proxyBeanMethods = false)
class TestcontainersConfiguration {

    @Bean
    @ServiceConnection
    fun postgresContainer(): PostgreSQLContainer<*> {
        return PostgreSQLContainer(DockerImageName.parse("postgis/postgis:16-3.4-alpine")
            .asCompatibleSubstituteFor("postgres"))
    }

    @Bean
    @ServiceConnection(name = "redis")
    fun redisContainer(): GenericContainer<*> {
        return GenericContainer(DockerImageName.parse("redis:7-alpine")).withExposedPorts(6379)
    }

    @Bean
    fun jwtDecoder(): org.springframework.security.oauth2.jwt.JwtDecoder {
        return org.springframework.security.oauth2.jwt.JwtDecoder { 
            throw org.springframework.security.oauth2.jwt.JwtException("Mock decoder") 
        }
    }
}
