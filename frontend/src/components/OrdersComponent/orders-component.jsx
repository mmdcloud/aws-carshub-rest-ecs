"use client";
import { useQuery } from "@tanstack/react-query";
import axiosInstance from "../../network/axiosInstance";
import PageLoader from "../../components/common/Loader/pageLoader";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import TableTwo from "@/components/Tables/TableTwo";
import { useRouter } from "next/navigation";
import { Download, Eye, X } from "lucide-react";
import axiosBlob from "@/network/axiosBlob";
import CustomAlert from "@/components/CustomAlert/Alert";
import { useAnimate } from "motion/react";
import { useEffect } from "react";

const renderActions = (item, key) => {
    const router = useRouter();
    return (
        <div key={key} className="flex items-center space-x-3.5">
            <button onClick={() => {
                var params = new URLSearchParams(item);
                router.push("/orders/" + params.get("id"));
            }} className="hover:text-primary">
                <Eye size={16} />
            </button>
            {/* <button onClick={ async () => {
                var params = new URLSearchParams(item);
                var response = await axiosBlob.get("/orders/generateInvoice/" + params.get("id"));
                const href = URL.createObjectURL(response.data);
                const link = document.createElement('a');
                link.href = href;
                link.setAttribute('download', 'invoice.pdf');
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                URL.revokeObjectURL(href);
            }} className="hover:text-primary">
                <Download size={16} />
            </button> */}
            <button className="hover:text-primary">
                <X size={16} />
            </button>
        </div>
    );
};

const tableDataKeys = [
    {
        header: "Id",
        key: "id"
    },
    {
        header: "Date",
        key: "date"
    },
    {
        header: "Discount",
        key: "discount"
    },
    {
        header: "Total Amount",
        key: "totalAmount"
    },
    {
        header: "Actions",
        component: renderActions
    }
]

const OrdersComponent = () => {
    const router = useRouter();
    const { data, error, isLoading, isError } = useQuery({
        queryKey: ["orders"],
        queryFn: () => {
            return axiosInstance.get("/orders");
        }
    });
    
    return (
        <>
            {
                isError ? <CustomAlert message={error.message} /> : isLoading ? <PageLoader /> : <TableTwo isActionVisible={true} actionOnClick={() => {
                    router.push("/orders/form");
                }} title={"Orders"} tableDataKeys={tableDataKeys} data={data.data} />
            }
        </>
    )
};
export default OrdersComponent;