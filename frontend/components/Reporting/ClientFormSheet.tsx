/**
 * Client Form Sheet
 *
 * Side panel form for creating and editing clients.
 */

"use client";

import { useState, useEffect } from "react";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
  SheetFooter,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Loader2 } from "lucide-react";

export interface ClientFormData {
  name: string;
  linearTeamKey: string;
  productiveId?: string;
}

interface ClientFormSheetProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSubmit: (data: ClientFormData) => Promise<void>;
  initialData?: ClientFormData;
  mode: "create" | "edit";
}

export function ClientFormSheet({
  open,
  onOpenChange,
  onSubmit,
  initialData,
  mode,
}: ClientFormSheetProps) {
  const [name, setName] = useState(initialData?.name ?? "");
  const [linearTeamKey, setLinearTeamKey] = useState(initialData?.linearTeamKey ?? "");
  const [productiveId, setProductiveId] = useState(initialData?.productiveId ?? "");
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Reset form when opening/closing or when initialData changes
  useEffect(() => {
    if (open) {
      setName(initialData?.name ?? "");
      setLinearTeamKey(initialData?.linearTeamKey ?? "");
      setProductiveId(initialData?.productiveId ?? "");
    }
  }, [open, initialData]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !linearTeamKey.trim()) return;

    setIsSubmitting(true);
    try {
      await onSubmit({
        name: name.trim(),
        linearTeamKey: linearTeamKey.trim().toUpperCase(),
        productiveId: productiveId.trim() || undefined,
      });
      onOpenChange(false);
    } finally {
      setIsSubmitting(false);
    }
  };

  const isValid = name.trim().length > 0 && linearTeamKey.trim().length > 0;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent>
        <form onSubmit={handleSubmit} className="flex h-full flex-col">
          <SheetHeader>
            <SheetTitle>
              {mode === "create" ? "Add New Client" : "Edit Client"}
            </SheetTitle>
            <SheetDescription>
              {mode === "create"
                ? "Create a new client for service reporting."
                : "Update the client details."}
            </SheetDescription>
          </SheetHeader>

          <div className="flex-1 space-y-4 overflow-y-auto p-4">
            <div className="space-y-2">
              <Label htmlFor="client-name">Client Name</Label>
              <Input
                id="client-name"
                placeholder="e.g., Acme Corporation"
                value={name}
                onChange={(e) => setName(e.target.value)}
                disabled={isSubmitting}
                autoFocus
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="linear-team-key">Linear Team Key</Label>
              <Input
                id="linear-team-key"
                placeholder="e.g., ACM"
                value={linearTeamKey}
                onChange={(e) => setLinearTeamKey(e.target.value)}
                disabled={isSubmitting}
                className="uppercase"
              />
              <p className="text-xs text-slate-500">
                The team key used in Linear (e.g., ACM for ACM-123)
              </p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="productive-id">Productive ID (Optional)</Label>
              <Input
                id="productive-id"
                placeholder="e.g., 12345"
                value={productiveId}
                onChange={(e) => setProductiveId(e.target.value)}
                disabled={isSubmitting}
              />
              <p className="text-xs text-slate-500">
                Link to Productive.io for contingent sync
              </p>
            </div>
          </div>

          <SheetFooter>
            <Button
              type="button"
              variant="secondary"
              onClick={() => onOpenChange(false)}
              disabled={isSubmitting}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={!isValid || isSubmitting}>
              {isSubmitting && <Loader2 className="mr-2 size-4 animate-spin" />}
              {mode === "create" ? "Add Client" : "Save Changes"}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  );
}
