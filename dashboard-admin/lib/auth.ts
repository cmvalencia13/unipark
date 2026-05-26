import NextAuth from 'next-auth';
import { JWT } from 'next-auth/jwt';
import type { Session } from '@/types';

declare module 'next-auth' {
  interface Session {
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

const keycloakUrl = process.env.KEYCLOAK_URL || 'http://localhost:8080';
const clientId = process.env.KEYCLOAK_CLIENT_ID || 'unipark-dashboard';
const clientSecret = process.env.KEYCLOAK_CLIENT_SECRET || '';
const realm = process.env.KEYCLOAK_REALM || 'unipark';

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    {
      id: 'keycloak',
      name: 'Keycloak',
      type: 'oidc',
      issuer: `${keycloakUrl}/realms/${realm}`,
      clientId,
      clientSecret,
      authorization: {
        params: {
          scope: 'openid profile email roles',
        },
      },
    },
  ],
  pages: {
    signIn: '/auth/signin',
  },
  callbacks: {
    async jwt({ token, account }) {
      if (account) {
        token.accessToken = account.access_token;
        token.refreshToken = account.refresh_token;
        token.expiresAt = account.expires_at ? account.expires_at * 1000 : 0;
      }

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
          return token;
        }
      }

      return token;
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken as string | undefined;
      session.refreshToken = token.refreshToken as string | undefined;
      session.expiresAt = token.expiresAt as number | undefined;
      return session;
    },
  },
  session: { strategy: 'jwt' },
});
