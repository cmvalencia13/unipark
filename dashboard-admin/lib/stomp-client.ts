import { Client, Message } from '@stomp/stompjs';
import SockJS from 'sockjs-client';

const WS_URL = process.env.NEXT_PUBLIC_WS_URL || 'https://api.unipark.local/ws';

let stompClient: Client | null = null;

export const initStompClient = (accessToken: string): Promise<Client> => {
  return new Promise((resolve, reject) => {
    // Use SockJS as fallback for better browser compatibility
    const socket = new SockJS(WS_URL, undefined, {
      transports: ['websocket', 'xhr-streaming', 'xhr-polling'],
    });

    const client = new Client({
      webSocketFactory: () => socket,
      connectHeaders: {
        login: 'admin',
        passcode: accessToken,
        Authorization: `Bearer ${accessToken}`,
      },
      debug: (str) => {
        if (process.env.NODE_ENV === 'development') {
          console.log('[STOMP]', str);
        }
      },
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
      onConnect: () => {
        stompClient = client;
        resolve(client);
      },
      onStompError: (frame) => {
        console.error('STOMP error:', frame);
        reject(new Error(`STOMP error: ${frame.body}`));
      },
      onWebSocketError: (error) => {
        console.error('WebSocket error:', error);
        reject(error);
      },
    });

    client.activate();
  });
};

export const getStompClient = (): Client | null => stompClient;

export const subscribeToOccupancy = (
  lotId: string,
  callback: (data: any) => void
): string => {
  if (!stompClient || !stompClient.connected) {
    console.error('STOMP client not connected');
    return '';
  }

  return stompClient.subscribe(`/topic/lots/${lotId}/occupancy`, (message: Message) => {
    const data = JSON.parse(message.body);
    callback(data);
  }).id;
};

export const subscribeToViolations = (callback: (data: any) => void): string => {
  if (!stompClient || !stompClient.connected) {
    console.error('STOMP client not connected');
    return '';
  }

  return stompClient.subscribe('/topic/violations', (message: Message) => {
    const data = JSON.parse(message.body);
    callback(data);
  }).id;
};

export const unsubscribe = (subscriptionId: string) => {
  if (stompClient && subscriptionId) {
    stompClient.unsubscribe(subscriptionId);
  }
};

export const disconnectStomp = () => {
  if (stompClient && stompClient.connected) {
    stompClient.deactivate();
    stompClient = null;
  }
};
