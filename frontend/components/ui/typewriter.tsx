/**
 * Typewriter Component
 *
 * Calm, one-time typewriter effect for Sabine's voice.
 * - Italic, Indigo blue text
 * - No loop, plays once
 * - Subtle cursor that fades after completion
 * - Fallback to static text if animation disabled
 */

"use client";

import { useState, useEffect } from "react";
import { cn } from "@/lib/utils";

interface TypewriterProps {
  text: string;
  /** Typing speed in ms per character (default: 30) */
  speed?: number;
  /** Delay before starting in ms (default: 500) */
  startDelay?: number;
  /** Show static text immediately without animation */
  static?: boolean;
  /** Additional className */
  className?: string;
  /** Callback when typing is complete */
  onComplete?: () => void;
}

export function Typewriter({
  text,
  speed = 30,
  startDelay = 500,
  static: isStatic = false,
  className,
  onComplete,
}: TypewriterProps) {
  const [displayedText, setDisplayedText] = useState(isStatic ? text : "");
  const [isComplete, setIsComplete] = useState(isStatic);
  const [showCursor, setShowCursor] = useState(!isStatic);

  useEffect(() => {
    // Skip animation if static mode
    if (isStatic) {
      setDisplayedText(text);
      setIsComplete(true);
      setShowCursor(false);
      return;
    }

    // Reset state for new animation
    setDisplayedText("");
    setIsComplete(false);
    setShowCursor(true);

    let currentIndex = 0;
    let timeoutId: NodeJS.Timeout;
    let cursorTimeoutId: NodeJS.Timeout;
    let cancelled = false;

    const typeNextChar = () => {
      if (cancelled) return;

      if (currentIndex < text.length) {
        setDisplayedText(text.slice(0, currentIndex + 1));
        currentIndex++;
        timeoutId = setTimeout(typeNextChar, speed);
      } else {
        setIsComplete(true);
        onComplete?.();
        // Fade out cursor after completion
        cursorTimeoutId = setTimeout(() => {
          if (!cancelled) setShowCursor(false);
        }, 1500);
      }
    };

    // Start typing after delay
    timeoutId = setTimeout(typeNextChar, startDelay);

    return () => {
      cancelled = true;
      clearTimeout(timeoutId);
      clearTimeout(cursorTimeoutId);
    };
  }, [text, speed, startDelay, isStatic, onComplete]);

  return (
    <p
      className={cn(
        "whitespace-pre-line text-sm italic text-indigo-400",
        className
      )}
    >
      {displayedText}
      {showCursor && (
        <span
          className={cn(
            "ml-0.5 inline-block h-4 w-0.5 bg-indigo-400 align-middle",
            isComplete && "animate-pulse opacity-50"
          )}
        />
      )}
    </p>
  );
}
