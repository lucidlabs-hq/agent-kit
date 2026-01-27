/**
 * AppSidebar Component (Icon-Rail)
 *
 * Minimal icon-only sidebar for navigation.
 * Width: 64px, labels shown as tooltips on hover.
 *
 * Customize navigation items for your application.
 */

"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Home, Settings, LogOut, Bot } from "lucide-react";
import { cn } from "@/lib/utils";

/**
 * Generate initials from a name (max 2 characters)
 */
function getInitials(name: string): string {
  const parts = name.trim().split(/\s+/);
  if (parts.length === 1) {
    return parts[0].charAt(0).toUpperCase();
  }
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
}

interface NavItemConfig {
  title: string;
  href: string;
  icon: React.ReactNode;
}

/**
 * Customize these navigation items for your application
 */
const primaryNavItems: NavItemConfig[] = [
  {
    title: "Dashboard",
    href: "/",
    icon: <Home className="size-5" />,
  },
  {
    title: "Agent",
    href: "/agent",
    icon: <Bot className="size-5" />,
  },
];

/**
 * Icon button with tooltip
 */
function IconNavItem({
  item,
  isActive,
}: {
  item: NavItemConfig;
  isActive: boolean;
}) {
  return (
    <Link
      href={item.href}
      className={cn(
        "group relative flex size-10 cursor-pointer items-center justify-center rounded-lg transition-all",
        isActive
          ? "bg-indigo-50 text-indigo-600"
          : "text-slate-400 hover:bg-slate-100 hover:text-slate-500"
      )}
    >
      {item.icon}

      {/* Tooltip */}
      <div className="pointer-events-none absolute left-full z-50 ml-2 flex items-center opacity-0 transition-opacity group-hover:opacity-100">
        <div className="whitespace-nowrap rounded-md bg-slate-900 px-2 py-1 text-xs font-medium text-white">
          {item.title}
        </div>
      </div>
    </Link>
  );
}

export function AppSidebar() {
  const pathname = usePathname();
  const router = useRouter();

  // TODO: Replace with actual user data from auth
  const userName = "User";
  const userInitials = getInitials(userName);

  const [avatarMenuOpen, setAvatarMenuOpen] = useState(false);
  const avatarMenuRef = useRef<HTMLDivElement>(null);

  const handleLogout = useCallback(() => {
    // TODO: Implement actual logout logic
    if (typeof window !== "undefined") {
      localStorage.clear();
    }
    router.push("/");
  }, [router]);

  // Close menu on outside click
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (avatarMenuRef.current && !avatarMenuRef.current.contains(event.target as Node)) {
        setAvatarMenuOpen(false);
      }
    }
    if (avatarMenuOpen) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [avatarMenuOpen]);

  return (
    <aside className="flex h-screen w-16 flex-col items-center border-r border-divider bg-slate-50 pb-3 pt-[46px]">
      {/* Logo - Replace with your app logo */}
      <Link
        href="/"
        className="flex h-8 w-10 cursor-pointer items-center justify-center rounded-lg transition-colors hover:bg-slate-100"
      >
        <Bot className="size-7 text-indigo-600" />
      </Link>

      {/* Divider */}
      <div className="my-3 h-px w-8 bg-divider" />

      {/* Primary Navigation */}
      <nav className="flex flex-col items-center gap-1">
        {primaryNavItems.map((item) => (
          <IconNavItem
            key={item.href}
            item={item}
            isActive={
              item.href === "/"
                ? pathname === "/"
                : pathname === item.href || pathname.startsWith(item.href + "/")
            }
          />
        ))}
      </nav>

      {/* Spacer */}
      <div className="flex-1" />

      {/* Bottom Actions */}
      <div className="flex flex-col items-center gap-1">
        {/* Settings */}
        <IconNavItem
          item={{
            title: "Settings",
            href: "/settings",
            icon: <Settings className="size-5" />,
          }}
          isActive={pathname === "/settings" || pathname.startsWith("/settings/")}
        />

        {/* Divider */}
        <div className="my-2 h-px w-8 bg-divider" />

        {/* User Avatar with Dropdown */}
        <div ref={avatarMenuRef} className="relative">
          <button
            type="button"
            onClick={() => setAvatarMenuOpen(!avatarMenuOpen)}
            className={cn(
              "flex size-10 cursor-pointer items-center justify-center rounded-full bg-slate-200 text-xs font-medium text-slate-600 transition-all hover:ring-2 hover:ring-primary/30",
              avatarMenuOpen && "ring-2 ring-primary/30"
            )}
          >
            {userInitials}
          </button>

          {/* Dropdown Menu */}
          {avatarMenuOpen && (
            <div className="absolute bottom-0 left-full z-50 ml-2 min-w-[160px] rounded-lg border border-divider bg-white py-1 shadow-lg">
              {/* User info */}
              <div className="border-b border-divider px-3 py-2">
                <p className="text-sm font-medium text-slate-900">{userName}</p>
              </div>

              {/* Logout */}
              <button
                type="button"
                onClick={handleLogout}
                className="flex w-full cursor-pointer items-center gap-2 px-3 py-2 text-sm text-slate-600 transition-colors hover:bg-slate-50"
              >
                <LogOut className="size-4" />
                <span>Log out</span>
              </button>
            </div>
          )}
        </div>
      </div>
    </aside>
  );
}
