import { Sidebar } from "@/components/layout/Sidebar";
import { Header } from "@/components/layout/Header";
import { auth } from "@/lib/auth";
import { redirect } from "next/navigation";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const session = await auth();
  if (!session?.user) redirect("/login");

  const role = (session.user as any).role as string;
  if (role !== "admin" && role !== "superadmin") {
    return (
      <div className="flex items-center justify-center h-screen">
        <p className="text-gray-500">You do not have permission to access this area.</p>
      </div>
    );
  }

  return (
    <>
      <Sidebar />
      <div className="ml-60">
        <Header />
        <main className="p-6">{children}</main>
      </div>
    </>
  );
}
