/**
 * Client Meeting Mode Page
 *
 * Interactive meeting mode for discussing tickets and recording decisions.
 * Supports starting, running, and ending meetings.
 */

import { ClientMeetingView } from "@/components/Reporting/MeetingMode/ClientMeetingView";

// Force dynamic rendering - Convex hooks require client-side provider
export const dynamic = "force-dynamic";

interface ClientMeetingPageProps {
  params: Promise<{ clientId: string }>;
}

export default async function ClientMeetingPage({ params }: ClientMeetingPageProps) {
  const { clientId } = await params;
  return <ClientMeetingView clientId={clientId} />;
}
