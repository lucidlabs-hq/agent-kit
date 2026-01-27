/**
 * AppShell Component
 *
 * Main layout wrapper with optional sidebar and content area.
 * Customize for your application needs.
 */

import { AppSidebar } from "./app-sidebar";

interface AppShellProps {
  children: React.ReactNode;
  /** Hide sidebar for full-width layouts */
  hideSidebar?: boolean;
}

export function AppShell({ children, hideSidebar = false }: AppShellProps) {
  return (
    <div className="flex h-screen bg-surface-0">
      {!hideSidebar && <AppSidebar />}
      <main className="flex-1 overflow-auto">
        {children}
      </main>
    </div>
  );
}
