import NextAuth from 'next-auth';
import Credentials from 'next-auth/providers/credentials';

const config = {
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
    async jwt({ token, user }: any) {
      if (user) {
        token.id = user.id;
        token.role = user.role || 'admin';
      }
      return token;
    },
    async session({ session, token }: any) {
      if (session.user) {
        session.user.id = token.id;
        session.user.role = token.role;
      }
      session.accessToken = token.sub || '';
      return session;
    },
  },
  session: { strategy: 'jwt' as const },
  secret: process.env.NEXTAUTH_SECRET,
};

const { handlers, auth, signIn, signOut } = NextAuth(config);

export { handlers, auth, signIn, signOut };
