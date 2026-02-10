/**
 * Reporting Layout
 *
 * Layout wrapper for client service reporting pages.
 * Provides Convex context and consistent structure.
 */

import { AppShell } from "@/components/Layout/app-shell";

interface ReportingLayoutProps {
  children: React.ReactNode;
}

export default function ReportingLayout({ children }: ReportingLayoutProps) {
  return <AppShell>{children}</AppShell>;
}
