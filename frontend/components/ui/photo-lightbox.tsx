/**
 * PhotoLightbox Component
 *
 * Simple lightbox for viewing photos in full size.
 * Uses Radix Dialog for accessibility.
 *
 * Features:
 * - Click thumbnail to open
 * - Click outside or X to close
 * - Navigate between multiple images
 * - Keyboard navigation (Escape to close, arrows to navigate)
 */

"use client";

import { useState, useEffect, useCallback } from "react";
import { X, ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "@/lib/utils";

interface Photo {
  id: string;
  src: string;
  label: string;
}

interface PhotoLightboxProps {
  photos: Photo[];
  initialIndex?: number;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

/**
 * Lightbox modal for viewing photos
 */
export function PhotoLightbox({
  photos,
  initialIndex = 0,
  open,
  onOpenChange,
}: PhotoLightboxProps) {
  // Initialize with initialIndex, reset when dialog opens
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [lastOpenState, setLastOpenState] = useState(open);

  // Reset to initial index when opening (using derived state pattern to avoid sync setState)
  if (open && !lastOpenState) {
    setCurrentIndex(initialIndex);
  }
  if (open !== lastOpenState) {
    setLastOpenState(open);
  }

  const currentPhoto = photos[currentIndex];
  const hasMultiple = photos.length > 1;

  const goNext = useCallback(() => {
    setCurrentIndex((prev) => (prev + 1) % photos.length);
  }, [photos.length]);

  const goPrev = useCallback(() => {
    setCurrentIndex((prev) => (prev - 1 + photos.length) % photos.length);
  }, [photos.length]);

  // Keyboard navigation
  useEffect(() => {
    if (!open) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        onOpenChange(false);
      } else if (e.key === "ArrowRight" && hasMultiple) {
        goNext();
      } else if (e.key === "ArrowLeft" && hasMultiple) {
        goPrev();
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [open, hasMultiple, goNext, goPrev, onOpenChange]);

  if (!open || !currentPhoto) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/80 animate-in fade-in duration-200"
        onClick={() => onOpenChange(false)}
      />

      {/* Close button */}
      <button
        type="button"
        onClick={() => onOpenChange(false)}
        className="absolute right-4 top-4 z-10 cursor-pointer rounded-full bg-black/50 p-2 text-white transition-colors hover:bg-black/70"
        aria-label="Schließen"
      >
        <X className="size-5" />
      </button>

      {/* Navigation - Previous */}
      {hasMultiple && (
        <button
          type="button"
          onClick={goPrev}
          className="absolute left-4 z-10 cursor-pointer rounded-full bg-black/50 p-2 text-white transition-colors hover:bg-black/70"
          aria-label="Vorheriges Foto"
        >
          <ChevronLeft className="size-6" />
        </button>
      )}

      {/* Image container */}
      <div className="relative z-10 max-h-[80vh] max-w-[90vw] animate-in zoom-in-95 duration-200">
        <img
          src={currentPhoto.src}
          alt={currentPhoto.label}
          className="max-h-[80vh] max-w-[90vw] rounded-lg object-contain"
        />

        {/* Image counter */}
        {hasMultiple && (
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 rounded-full bg-black/50 px-3 py-1 text-sm text-white">
            {currentIndex + 1} / {photos.length}
          </div>
        )}
      </div>

      {/* Navigation - Next */}
      {hasMultiple && (
        <button
          type="button"
          onClick={goNext}
          className="absolute right-4 z-10 cursor-pointer rounded-full bg-black/50 p-2 text-white transition-colors hover:bg-black/70"
          aria-label="Nächstes Foto"
        >
          <ChevronRight className="size-6" />
        </button>
      )}
    </div>
  );
}

/**
 * Photo thumbnail that opens lightbox on click
 */
interface PhotoThumbnailWithLightboxProps {
  photo: Photo;
  photos: Photo[];
  className?: string;
}

export function PhotoThumbnailWithLightbox({
  photo,
  photos,
  className,
}: PhotoThumbnailWithLightboxProps) {
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const photoIndex = photos.findIndex((p) => p.id === photo.id);

  return (
    <>
      <button
        type="button"
        onClick={() => setLightboxOpen(true)}
        className={cn(
          "relative aspect-square w-full cursor-pointer overflow-hidden rounded border border-slate-200 transition-all hover:border-slate-300 hover:opacity-90",
          className
        )}
      >
        <img
          src={photo.src}
          alt={photo.label}
          className="size-full object-cover"
        />
      </button>

      <PhotoLightbox
        photos={photos}
        initialIndex={photoIndex >= 0 ? photoIndex : 0}
        open={lightboxOpen}
        onOpenChange={setLightboxOpen}
      />
    </>
  );
}
