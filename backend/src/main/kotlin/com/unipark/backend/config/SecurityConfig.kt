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

    /**
     * Mock JWT decoder para desarrollo local sin Keycloak.
     * El token actúa como alias del usuario:
     *   "dev-mock-token-driver" → María García (conductor, V003)
     *   "dev-mock-token-guard"  → Carlos Guardián (guardia, V003)
     *   "dev-mock-token-admin"  → Admin Demo (admin, V003)
     *   Cualquier UUID válido   → se usa directamente como sub
     *
     * Fase 2 (Keycloak real): eliminar este bean y agregar en application.properties:
     *   spring.security.oauth2.resourceserver.jwt.issuer-uri=https://<keycloak>/realms/unipark
     */
    @Bean
    fun jwtDecoder(): JwtDecoder {
        val tokenMap = mapOf(
            "dev-mock-token-driver" to "c3d4e5f6-a7b8-9012-cdef-123456789012", // María García
            "dev-mock-token-guard"  to "d4e5f6a7-b8c9-0123-def0-234567890123", // Carlos Guardián
            "dev-mock-token-admin"  to "e5f6a7b8-c9d0-1234-ef01-345678901234"  // Admin Demo
        )
        return JwtDecoder { token ->
            val sub = tokenMap[token] ?: token // UUID directo si no es un alias conocido
            Jwt.withTokenValue(token)
                .header("alg", "none")
                .claim("sub", sub)
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
