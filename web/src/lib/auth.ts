import NextAuth from "next-auth";
import Auth0 from "next-auth/providers/auth0";
import { authConfig } from "./auth.config";

export const { handlers, signIn, signOut, auth } = NextAuth({
  ...authConfig,
  providers: [
    Auth0({
      clientId: process.env.AUTH0_CLIENT_ID!,
      clientSecret: process.env.AUTH0_CLIENT_SECRET!,
      issuer: process.env.AUTH0_ISSUER!, // p.ej. https://TU_DOMINIO.us.auth0.com
      authorization: {
        params: {
          // OBLIGATORIO: sin audience el access token es opaco y el backend lo rechaza.
          audience: process.env.AUTH0_AUDIENCE ?? "https://api.unipark.edu.sv",
          scope: "openid profile email",
        },
      },
    }),
  ],
});
