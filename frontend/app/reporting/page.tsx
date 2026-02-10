/**
 * Reporting Dashboard Page
 *
 * Overview of all clients with stats and contingent status.
 * Entry point for client service reporting.
 */

import { ReportingDashboard } from "@/components/Reporting/ReportingDashboard";

// Force dynamic rendering - Convex hooks require client-side provider
export const dynamic = "force-dynamic";

export default function ReportingPage() {
  return <ReportingDashboard />;
}
