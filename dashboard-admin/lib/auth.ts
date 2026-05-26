import NextAuth from 'next-auth';
import Credentials from 'next-auth/providers/credentials';

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    Credentials({
      name: 'Demo',
      credentials: {
        email: { label: 'Email', type: 'email', placeholder: 'admin@unipark.edu' },
      },
      async authorize(credentials) {
        // Demo: cualquier email funciona en desarrollo
        if (credentials?.email) {
          return {
            id: '1',
            name: 'Admin',
            email: credentials.email as string,
            role: 'admin',
          };
        }
        return null;
      },
    }),
  ],
  pages: {
    signIn: '/auth/signin',
  },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id;
        token.role = (user as any).role || 'admin';
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
        (session.user as any).role = token.role;
      }
      session.accessToken = token.sub || '';
      return session;
    },
  },
  session: { strategy: 'jwt' },
});
