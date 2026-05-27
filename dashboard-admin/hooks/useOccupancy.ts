'use client';

import { useEffect, useState, useCallback } from 'react';
import { useQuery } from '@tanstack/react-query';
import { api } from '@/lib/api-client';
import { useWebSocket } from './useWebSocket';
import { ParkingLot, OccupancyEvent } from '@/types';

export const useOccupancy = () => {
  const [lots, setLots] = useState<ParkingLot[]>([]);
  const [loading, setLoading] = useState(true);
  const { subscribeOccupancy } = useWebSocket();

  const fetchLots = useCallback(async () => {
    try {
      const response = await api.getLots();
      setLots(response.data);
      setLoading(false);
    } catch (error) {
      console.error('Failed to fetch lots:', error);
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchLots();
  }, [fetchLots]);

  useEffect(() => {
    const subscriptions: string[] = [];

    lots.forEach((lot) => {
      const subId = subscribeOccupancy(lot.id, (event: OccupancyEvent) => {
        setLots((prevLots) =>
          prevLots.map((l) =>
            l.id === event.lotId
              ? {
                  ...l,
                  capacityUsed: event.used,
                  capacity: event.total,
                  percentage: (event.used / event.total) * 100,
                }
              : l
          )
        );
      });

      if (subId) subscriptions.push(subId);
    });

    return () => {
      subscriptions.forEach((subId) => {
        // Cleanup handled by useWebSocket
      });
    };
  }, [lots, subscribeOccupancy]);

  return { lots, loading, refetch: fetchLots };
};
