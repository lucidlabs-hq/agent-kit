/**
 * Client Goals Page
 *
 * Strategic goals management with CRUD operations.
 * Supports reordering via drag-and-drop.
 */

import { ClientGoalsView } from "@/components/Reporting/ClientGoalsView";

// Force dynamic rendering - Convex hooks require client-side provider
export const dynamic = "force-dynamic";

interface ClientGoalsPageProps {
  params: Promise<{ clientId: string }>;
}

export default async function ClientGoalsPage({ params }: ClientGoalsPageProps) {
  const { clientId } = await params;
  return <ClientGoalsView clientId={clientId} />;
}
