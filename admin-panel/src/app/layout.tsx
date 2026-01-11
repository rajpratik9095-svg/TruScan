import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "TrueScan Admin Panel",
  description: "Admin dashboard for TrueScan app management",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="bg-gray-100 dark:bg-gray-900">
        {children}
      </body>
    </html>
  );
}
