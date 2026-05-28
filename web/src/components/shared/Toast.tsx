"use client";

import { useEffect, useState } from "react";

interface ToastData {
  message: string;
  type: "success" | "error";
}

let toastListeners: ((data: ToastData) => void)[] = [];

export function showToast(message: string, type: "success" | "error" = "success") {
  toastListeners.forEach((fn) => fn({ message, type }));
}

export function Toast() {
  const [toast, setToast] = useState<ToastData | null>(null);

  useEffect(() => {
    toastListeners.push(setToast);
    return () => {
      toastListeners = toastListeners.filter((fn) => fn !== setToast);
    };
  }, []);

  useEffect(() => {
    if (toast) {
      const timer = setTimeout(() => setToast(null), 4000);
      return () => clearTimeout(timer);
    }
  }, [toast]);

  if (!toast) return null;

  return (
    <div
      className={`fixed bottom-6 right-6 z-50 px-4 py-3 rounded-lg text-body-md font-medium shadow-lg transition-all ${
        toast.type === "success"
          ? "bg-secondary-container/20 text-secondary-fixed border border-secondary-fixed/30"
          : "bg-error-container/20 text-error border border-error/30"
      }`}
    >
      {toast.message}
    </div>
  );
}
