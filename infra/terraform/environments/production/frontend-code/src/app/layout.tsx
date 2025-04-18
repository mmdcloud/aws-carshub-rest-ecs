"use client";
import "jsvectormap/dist/jsvectormap.css";
import "flatpickr/dist/flatpickr.min.css";
import "@/css/satoshi.css";
import "@/css/style.css";
import React, { useEffect, useState } from "react";
import Loader from "@/components/common/Loader";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "react-hot-toast";
import { persistor } from '../redux/store';
import { ReduxProvider } from "@/redux/reduxProvider";
import { PersistGate } from "redux-persist/lib/integration/react";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    setTimeout(() => setLoading(false), 1000);
  }, []);
  const [queryClient, setQueryClient] = React.useState(new QueryClient({}))
  return (
    <html lang="en">
      <body suppressHydrationWarning={true}>
        <title>CarsHub Admin Dashboard</title>
        <ReduxProvider>
          <PersistGate loading={null} persistor={persistor}>
            <Toaster />
            <QueryClientProvider client={queryClient}>
              <div className="dark:bg-boxdark-2 dark:text-bodydark">
                {loading ? <Loader /> : children}
              </div>
            </QueryClientProvider>
          </PersistGate>
        </ReduxProvider>
      </body>
    </html>
  );
}
