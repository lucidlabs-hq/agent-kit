/**
 * Client Tickets Page
 *
 * Full ticket list with filtering and sorting.
 * URL-based filters for shareability.
 */

import { ClientTicketsView } from "@/components/Reporting/ClientTicketsView";

// Force dynamic rendering - Convex hooks require client-side provider
export const dynamic = "force-dynamic";

interface ClientTicketsPageProps {
  params: Promise<{ clientId: string }>;
}

export default async function ClientTicketsPage({ params }: ClientTicketsPageProps) {
  const { clientId } = await params;
  return <ClientTicketsView clientId={clientId} />;
}
