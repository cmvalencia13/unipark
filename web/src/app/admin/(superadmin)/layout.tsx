import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";

export default async function SuperadminLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();
  if (!session?.user) redirect("/login");

  const role = (session.user as any).role as string;
  if (role !== "superadmin") redirect("/admin/dashboard");

  return <>{children}</>;
}
