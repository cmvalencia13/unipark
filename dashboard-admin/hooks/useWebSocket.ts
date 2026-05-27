'use client';

import { useEffect, useRef, useCallback } from 'react';
import { useSession } from 'next-auth/react';
import {
  initStompClient,
  subscribeToOccupancy,
  subscribeToViolations,
  unsubscribe,
  disconnectStomp,
} from '@/lib/stomp-client';

export const useWebSocket = () => {
  const { data: session } = useSession();
  const subscriptionRefs = useRef<string[]>([]);
  const isConnected = useRef(false);

  const connect = useCallback(async () => {
    if (!session?.accessToken || isConnected.current) return;

    try {
      await initStompClient(session.accessToken);
      isConnected.current = true;
    } catch (error) {
      console.error('Failed to connect WebSocket:', error);
      isConnected.current = false;
    }
  }, [session?.accessToken]);

  const subscribeOccupancy = useCallback(
    (lotId: string, callback: (data: any) => void) => {
      if (!isConnected.current) return;
      const subId = subscribeToOccupancy(lotId, callback);
      if (subId) subscriptionRefs.current.push(subId);
      return subId;
    },
    []
  );

  const subscribeViolations = useCallback((callback: (data: any) => void) => {
    if (!isConnected.current) return;
    const subId = subscribeToViolations(callback);
    if (subId) subscriptionRefs.current.push(subId);
    return subId;
  }, []);

  const unsubscribeAll = useCallback(() => {
    subscriptionRefs.current.forEach((subId) => unsubscribe(subId));
    subscriptionRefs.current = [];
  }, []);

  const disconnect = useCallback(() => {
    unsubscribeAll();
    disconnectStomp();
    isConnected.current = false;
  }, [unsubscribeAll]);

  useEffect(() => {
    connect();

    return () => {
      disconnect();
    };
  }, [connect, disconnect]);

  return {
    isConnected: isConnected.current,
    subscribeOccupancy,
    subscribeViolations,
    unsubscribeAll,
    disconnect,
  };
};
