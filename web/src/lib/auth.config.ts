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
        return true;
      }

      if (isLoggedIn) {
        return Response.redirect(new URL("/admin/dashboard", nextUrl));
      }
      return true;
    },
    jwt({ token, user, account }) {
      if (user) {
        token.sub = user.id!;
      }
      if (account?.access_token) {
        const payload = account.access_token.split(".")[1];
        const decoded = JSON.parse(Buffer.from(payload, "base64").toString());
        const roles: string[] = decoded?.realm_access?.roles ?? [];
        (token as any).role = roles.includes("superadmin")
          ? "superadmin"
          : roles.includes("admin")
            ? "admin"
            : null;
        (token as any).idToken = account.id_token;
      }
      return token;
    },
    session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub!;
        (session.user as any).role = (token as any).role;
      }
      (session as any).idToken = (token as any).idToken;
      return session;
    },
  },
  providers: [],
};
