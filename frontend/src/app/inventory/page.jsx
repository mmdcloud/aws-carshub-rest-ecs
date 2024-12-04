"use client";
import { useQuery } from "@tanstack/react-query";
import axiosInstance from "../../network/axiosInstance";
import DefaultLayout from "@/components/Layouts/DefaultLayout";
import PageLoader from "../../components/common/Loader/pageLoader";
import TableTwo from "@/components/Tables/TableTwo";
import { useRouter } from "next/navigation";
import { Eye, Pencil, X } from "lucide-react";
import CustomAlert from "@/components/CustomAlert/Alert";

const renderActions = (item, key) => {
    const router = useRouter();
    return (
        <div key={key} className="flex items-center space-x-3.5">
            <button onClick={() => {
                var params = new URLSearchParams(item);
                router.push("/inventory/" + params.get("id"));
            }} className="hover:text-primary">
                <Eye size={16} />
            </button>
            {
                item.status !== "Completed" && <button onClick={() => {
                    var params = new URLSearchParams(item);
                    router.push("/inventory/form?" + params);
                }} className="hover:text-primary">
                    <Pencil size={16} />
                </button>
            }
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
        header: "Price",
        key: "price"
    },
    {
        header: "Registration Year",
        key: "registrationYear"
    },
    {
        header: "Status",
        key: "status"
    },
    {
        header: "Actions",
        component: renderActions
    }
]

const Inventory = () => {
    const router = useRouter();
    const { data, error, isLoading, isError } = useQuery({
        queryKey: ["inventory"],
        queryFn: () => {
            return axiosInstance.get("/inventory");
        }
    })
    return (
        <DefaultLayout>
            {
                isError ? <CustomAlert message={error.message} /> : isLoading ? <PageLoader /> : <TableTwo isActionVisible={true} actionOnClick={() => {
                    router.push("/inventory/form");
                }} title={"Inventory"} tableDataKeys={tableDataKeys} data={data.data} />
            }
        </DefaultLayout>
    )
};
export default Inventory;