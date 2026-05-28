export interface ParkingLot {
  id: string;
  name: string;
  capacity: number;
  capacityUsed: number;
  percentage: number;
}

export interface OccupancyEvent {
  lotId: string;
  used: number;
  total: number;
  timestamp: string;
}

export interface Alert {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'warning' | 'error';
  timestamp: string;
}

export interface Violation {
  id: string;
  driverId: string;
  licenseplate: string;
  lotId: string;
  description: string;
  timestamp: string;
  status: 'PENDING' | 'APPROVED' | 'DISMISSED';
}

export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'guard' | 'driver';
  university_id?: string;
}

export interface Session {
  user: User;
  accessToken: string;
  expiresAt: number;
}
