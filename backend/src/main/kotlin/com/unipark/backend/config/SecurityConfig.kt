package com.unipark.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.web.SecurityFilterChain

@Configuration
@EnableWebSecurity
@EnableMethodSecurity // Permite usar @PreAuthorize
class SecurityConfig {

    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .csrf { it.disable() }
            .authorizeHttpRequests { auth ->
                auth.requestMatchers(HttpMethod.GET, "/v1/lots").permitAll()
                auth.requestMatchers(HttpMethod.GET, "/v1/lots/**").permitAll()
                auth.requestMatchers("/v1/**").authenticated()
                auth.anyRequest().permitAll()
            }
            .oauth2ResourceServer { oauth2 ->
                oauth2.jwt { jwt ->
                    jwt.jwtAuthenticationConverter(jwtAuthenticationConverter())
                }
            }

        return http.build()
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        return JwtDecoder { token ->
            Jwt.withTokenValue(token)
                .header("alg", "none")
                .claim("sub", "d4e5f6a7-b8c9-0123-def0-234567890123") // Carlos Guardián (guard, seeded in V003)
                .claim("role", listOf("driver", "guard", "admin"))
                .build()
        }
    }

    @Bean
    fun jwtAuthenticationConverter(): JwtAuthenticationConverter {
        val converter = JwtAuthenticationConverter()
        converter.setJwtGrantedAuthoritiesConverter { jwt ->
            // Dev mock: roles in "role" claim. Keycloak: roles in realm_access.roles
            val realmAccess = jwt.claims["realm_access"] as? Map<*, *>
            val claim = realmAccess?.get("roles") ?: jwt.claims["role"]
            val roles = when (claim) {
                is List<*> -> claim.mapNotNull { it?.toString() }
                is String -> listOf(claim)
                else -> emptyList()
            }
            roles.map { role -> SimpleGrantedAuthority("ROLE_${role.uppercase()}") }
        }
        return converter
    }
}
