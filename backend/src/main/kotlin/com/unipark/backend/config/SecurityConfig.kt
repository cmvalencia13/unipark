package com.unipark.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.core.authority.SimpleGrantedAuthority
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
    fun jwtAuthenticationConverter(): JwtAuthenticationConverter {
        val converter = JwtAuthenticationConverter()
        // El principal es el email del JWT, no el `sub`. Así el backend resuelve el
        // usuario local por email y no depende de que el UUID de Keycloak == users.id.
        converter.setPrincipalClaimName("email")
        converter.setJwtGrantedAuthoritiesConverter { jwt ->
            // Keycloak: roles en realm_access.roles
            val realmAccess = jwt.claims["realm_access"] as? Map<*, *>
            val claim = realmAccess?.get("roles") ?: jwt.claims["role"]
            val roles = when (claim) {
                is List<*> -> claim.mapNotNull { it?.toString() }
                is String  -> listOf(claim)
                else       -> emptyList()
            }
            roles.map { role -> SimpleGrantedAuthority("ROLE_${role.uppercase()}") }
        }
        return converter
    }
}
