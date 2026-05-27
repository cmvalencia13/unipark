import type { NextAuthConfig } from "next-auth";

export const authConfig: NextAuthConfig = {
  pages: {
    signIn: "/login",
  },
  callbacks: {
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user;
      const isAdminRoute = nextUrl.pathname.startsWith("/admin");

      if (isAdminRoute) {
        if (!isLoggedIn) return false;
        const role = (auth?.user as any)?.role as string;
        if (
          nextUrl.pathname.startsWith("/admin/users") ||
          nextUrl.pathname.startsWith("/admin/audit") ||
          nextUrl.pathname.startsWith("/admin/settings")
        ) {
          return role === "superadmin";
        }
        return role === "admin" || role === "superadmin";
      }

      if (isLoggedIn) {
        return Response.redirect(new URL("/admin/dashboard", nextUrl));
      }
      return true;
    },
    jwt({ token, user }) {
      if (user) {
        (token as any).role = (user as any).role;
        token.sub = user.id;
      }
      return token;
    },
    session({ session, token }) {
      if (session.user) {
        (session.user as any).role = (token as any).role as string;
        session.user.id = token.sub!;
      }
      return session;
    },
  },
  providers: [],
};
