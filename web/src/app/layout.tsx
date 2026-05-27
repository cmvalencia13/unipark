import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "UniPark Admin",
  description: "University Parking Management — Admin Dashboard",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className="dark">
      <body className="bg-[#111317] text-[#e2e2e8] font-sans antialiased min-h-screen">
        {children}
      </body>
    </html>
  );
}
