/**
 * ClientDetailHeader Component
 *
 * Header section for client detail pages.
 * Shows client info, contingent status, and navigation.
 */

"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Badge } from "@/components/ui/badge";
import { ContingentBar } from "./ContingentBar";
import type { Client, Contingent } from "@/lib/types/domain";
import { cn } from "@/lib/utils";

interface ClientDetailHeaderProps {
  client: Client;
  contingent: Contingent | null;
}

interface TabConfig {
  href: string;
  label: string;
}

export function ClientDetailHeader({
  client,
  contingent,
}: ClientDetailHeaderProps) {
  const pathname = usePathname();
  const basePath = `/reporting/${client._id}`;

  const tabs: TabConfig[] = [
    { href: basePath, label: "Overview" },
    { href: `${basePath}/tickets`, label: "Tickets" },
    { href: `${basePath}/goals`, label: "Goals" },
    { href: `${basePath}/meeting`, label: "Meeting" },
  ];

  const isActive = (href: string) => {
    if (href === basePath) {
      return pathname === basePath;
    }
    return pathname.startsWith(href);
  };

  return (
    <div className="border-b border-slate-100">
      <div className="flex items-start justify-between px-8 pb-4 pt-[46px]">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-semibold text-slate-900">
              {client.name}
            </h1>
            <Badge variant="muted">{client.linearTeamKey}</Badge>
          </div>
          <Link
            href="/reporting"
            className="mt-1 text-sm text-slate-500 transition-colors hover:text-indigo-600"
          >
            ← Back to clients
          </Link>
        </div>

        {contingent && (
          <div className="w-48">
            <ContingentBar
              showLabel
              totalHours={contingent.totalHours}
              usedHours={contingent.usedHours}
            />
          </div>
        )}
      </div>

      <nav className="flex gap-1 px-8">
        {tabs.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            className={cn(
              "cursor-pointer border-b-2 px-4 py-2 text-sm font-medium transition-colors",
              isActive(tab.href)
                ? "border-indigo-600 text-indigo-600"
                : "border-transparent text-slate-500 hover:border-slate-200 hover:text-slate-700"
            )}
          >
            {tab.label}
          </Link>
        ))}
      </nav>
    </div>
  );
}
