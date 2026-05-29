import { signIn } from "@/lib/auth";
import { redirect } from "next/navigation";

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="glass-panel rounded-xl p-lg max-w-md w-full mx-4 text-center">
        <h1 className="font-sora text-headline-lg text-primary-fixed-dim mb-2">UniPark</h1>
        <p className="text-on-surface-variant text-body-md mb-md">Admin Dashboard</p>
        <form
          action={async () => {
            "use server";
            await signIn("auth0", { redirectTo: "/admin/dashboard" });
          }}
        >
          <button
            type="submit"
            className="w-full bg-primary-fixed text-on-primary-fixed font-label-md py-3 px-4 rounded-lg hover:opacity-90 transition-all"
          >
            Sign in with University Account
          </button>
        </form>
        <p className="text-outline text-label-sm mt-sm">@universidad.edu accounts only</p>
      </div>
    </div>
  );
}
