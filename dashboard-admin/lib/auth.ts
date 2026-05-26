import NextAuth from 'next-auth';
import { JWT } from 'next-auth/jwt';
import KeycloakProvider from 'next-auth/providers/keycloak';
import { Session } from '@/types';

declare module 'next-auth' {
  interface Session extends Session {
    accessToken?: string;
    refreshToken?: string;
    expiresAt?: number;
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    accessToken?: string;
    refreshToken?: string;
    expiresAt?: number;
  }
}

const keycloakUrl = process.env.KEYCLOAK_URL || 'https://auth.unipark.local';
const clientId = process.env.KEYCLOAK_CLIENT_ID || 'unipark-dashboard';
const clientSecret = process.env.KEYCLOAK_CLIENT_SECRET || '';
const realm = process.env.KEYCLOAK_REALM || 'unipark';

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    KeycloakProvider({
      clientId,
      clientSecret,
      issuer: `${keycloakUrl}/realms/${realm}`,
      authorization: {
        params: {
          scope: 'openid profile email roles',
        },
      },
    }),
  ],
  pages: {
    signIn: '/auth/signin',
    error: '/auth/error',
  },
  callbacks: {
    async jwt({ token, account }) {
      if (account) {
        token.accessToken = account.access_token;
        token.refreshToken = account.refresh_token;
        token.expiresAt = (account.expires_at || 0) * 1000;
      }

      // Refresh token if expired
      if (token.expiresAt && Date.now() >= token.expiresAt) {
        try {
          const response = await fetch(
            `${keycloakUrl}/realms/${realm}/protocol/openid-connect/token`,
            {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: new URLSearchParams({
                client_id: clientId,
                client_secret: clientSecret,
                grant_type: 'refresh_token',
                refresh_token: token.refreshToken || '',
              }),
            }
          );

          const refreshedTokens = await response.json();

          if (!response.ok) throw refreshedTokens;

          return {
            ...token,
            accessToken: refreshedTokens.access_token,
            refreshToken: refreshedTokens.refresh_token ?? token.refreshToken,
            expiresAt: Date.now() + refreshedTokens.expires_in * 1000,
          };
        } catch (error) {
          console.error('Token refresh failed:', error);
          return { ...token, error: 'RefreshAccessTokenError' };
        }
      }

      return token;
    },
    async session({ session, token }) {
      if (token.error === 'RefreshAccessTokenError') {
        return null;
      }

      return {
        ...session,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        expiresAt: token.expiresAt,
      };
    },
  },
  session: { strategy: 'jwt' },
  jwt: {
    secret: process.env.NEXTAUTH_SECRET,
    maxAge: 24 * 60 * 60, // 24 hours
  },
});
