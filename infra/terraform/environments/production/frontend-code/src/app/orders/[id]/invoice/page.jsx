// import styles from "./invoice.module.css";
"use client";
import PageLoader from "@/components/common/Loader/pageLoader";
import axiosInstance from "@/network/axiosInstance";
import { useQuery } from "@tanstack/react-query";
import { useParams } from "next/navigation";

const Invoice = () => {
    const params = useParams();
    const { data, isLoading, error } = useQuery({
        queryKey: ["order-details"],
        queryFn: () => {
            console.log(params.id);
            return axiosInstance.get("/orders/getOrderDetailsWithExtraServices/"+ params.id);
        }
    });
    if (isLoading) {
        return <div className="flex items-center justify-center h-screen w-screen">
            <PageLoader />
        </div>
    }
    if (error) {
        return <p>{error.message}</p>
    }
    return <div style={{ maxWidth: "1200px", margin: "20px auto", backgroundColor: "#ffffff", padding: "40px", borderRadius: "8px", boxShadow: "0 2px 10px rgba(0, 0, 0, 0.1)" }}>
        <div style={{ textAlign: "center", marginBottom: "40px" }}>
            <h1 style={{ fontSize: "36px", color: "#007bff", marginBottom: "5px" }}>Invoice</h1>
            <p style={{ fontSize: "16px", color: "#555", marginTop: "20px" }}>Invoice Number: {data.data.orderData["id"]} | Date: {data.data.orderData["date"]}</p>
        </div>

        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "30px" }}>
            <div style={{ width: "48%" }}>
                <h3 style={{ fontSize: "20px", color: "#007bff", marginBottom: "10px" }}>Bill To:</h3>
                <p style={{ fontSize: "14px", color: "#555" }}>{data.data.orderData["buyer"]["fullname"]}</p>
                <p style={{ fontSize: "14px", color: "#555" }}>{data.data.orderData["buyer"]["city"]}</p>
                <p style={{ fontSize: "14px", color: "#555" }}>Contact: {data.data.orderData["buyer"]["contact"]}</p>
                <p style={{ fontSize: "14px", color: "#555" }}>Email: {data.data.orderData["buyer"]["email"]}</p>
            </div>
            <div style={{ width: "48%" }}>
                <h3 style={{ fontSize: "20px", color: "#007bff", marginBottom: "10px" }}>Invoice From:</h3>
                <p style={{ fontSize: "14px", color: "#555" }}>CarsHub</p>
                <p style={{ fontSize: "14px", color: "#555" }}>5678 Oak Avenue</p>
                <p style={{ fontSize: "14px", color: "#555" }}>Chicago, IL 60007</p>
                <p style={{ fontSize: "14px", color: "#555" }}>Email: contact@company.com</p>
            </div>
        </div>

        <table style={{
            width: "100%",
            borderCollapse: "collapse",
            marginBottom: "40px"
        }}>
            <thead>
                <tr>
                    <th style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#f7f7f7",
                        color: "#333",
                        fontWeight: "bold"
                    }}>Description</th>
                    <th style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#f7f7f7",
                        color: "#333",
                        fontWeight: "bold"
                    }}>Quantity</th>
                    <th style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#f7f7f7",
                        color: "#333",
                        fontWeight: "bold"
                    }}>Unit Price</th>
                    <th style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#f7f7f7",
                        color: "#333",
                        fontWeight: "bold"
                    }}>Total</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#fff"
                    }}>{data.data.orderData["inventory"]["model"]["brand"]["name"]} {data.data.orderData["inventory"]["model"]["name"]}</td>
                    <td style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#fff"
                    }}>1</td>
                    <td style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#fff"
                    }}>₹ {data.data.orderData["inventory"]["price"]}</td>
                    <td style={{
                        padding: "12px 15px",
                        textAlign: "left",
                        border: "1px solid #ddd",
                        backgroundColor: "#fff"
                    }}>₹ {parseFloat(data.data.orderData["inventory"]["price"]) * 1}</td>
                </tr>

                {
                    data.data.extraServices.map((x) => {
                        return <tr>
                            <td style={{
                                padding: "12px 15px",
                                textAlign: "left",
                                border: "1px solid #ddd",
                                backgroundColor: "#fff"
                            }}>{x["title"]}</td>
                            <td style={{
                                padding: "12px 15px",
                                textAlign: "left",
                                border: "1px solid #ddd",
                                backgroundColor: "#fff"
                            }}>1</td>
                            <td style={{
                                padding: "12px 15px",
                                textAlign: "left",
                                border: "1px solid #ddd",
                                backgroundColor: "#fff"
                            }}>₹ {x["price"]}</td>
                            <td style={{
                                padding: "12px 15px",
                                textAlign: "left",
                                border: "1px solid #ddd",
                                backgroundColor: "#fff"
                            }}>₹ {parseFloat(x["price"]) * 1}</td>
                        </tr>
                    })
                }
            </tbody>
        </table>

        <div style={{ display: "flex", justifyContent: "flex-end", fontSize: "16px" }}>
            <table style={{ width: "30%", border: "none", marginLeft: "20px" }}>
                <tr>
                    <th style={{ border: "none", textAlign: "right", padding: "8px 0", fontWeight: "normal", color: "#007bff" }}>Subtotal:</th>
                    <td style={{ border: "none", textAlign: "right", padding: "8px 0", color: "#333", fontWeight: "bold" }}>₹ { parseFloat(data.data.orderData["inventory"]["price"]) + data.data.extraServices.reduce((n, {price}) => n + parseFloat(price), 0) }</td>
                </tr>
                <tr>
                    <th style={{ border: "none", textAlign: "right", padding: "8px 0", fontWeight: "normal", color: "#007bff" }}>Tax (5%):</th>
                    <td style={{ border: "none", textAlign: "right", padding: "8px 0", color: "#333", fontWeight: "bold" }}>₹ { (parseFloat(data.data.orderData["inventory"]["price"]) + data.data.extraServices.reduce((n, {price}) => n + parseFloat(price), 0)) * 0.05 }</td>
                </tr>
                <tr>
                    <th style={{ border: "none", textAlign: "right", padding: "8px 0", fontWeight: "normal", color: "#007bff" }}>Total Amount:</th>
                    <td style={{ border: "none", textAlign: "right", padding: "8px 0", color: "#333", fontWeight: "bold" }}>₹ { (parseFloat(data.data.orderData["inventory"]["price"]) + data.data.extraServices.reduce((n, {price}) => n + parseFloat(price), 0)) + ((parseFloat(data.data.orderData["inventory"]["price"]) + data.data.extraServices.reduce((n, {price}) => n + parseFloat(price), 0)) * 0.05) }</td>
                </tr>
            </table>
        </div>
        <div style={{ textAlign: "center", marginTop: "30px", fontSize: "14px", color: "#777" }}>
            <p>Thank you for your business!</p>
            <p>If you have any questions regarding this invoice, please contact us at contact@company.com</p>
        </div>
    </div>

};
export default Invoice;