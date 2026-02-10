/**
 * Client Detail Page
 *
 * Overview of a single client with stats and recent activity.
 * Tab navigation to tickets, goals, and meeting mode.
 */

import { ClientDetailView } from "@/components/Reporting/ClientDetailView";

// Force dynamic rendering - Convex hooks require client-side provider
export const dynamic = "force-dynamic";

interface ClientDetailPageProps {
  params: Promise<{ clientId: string }>;
}

export default async function ClientDetailPage({ params }: ClientDetailPageProps) {
  const { clientId } = await params;
  return <ClientDetailView clientId={clientId} />;
}
