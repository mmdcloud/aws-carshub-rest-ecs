import axios from 'axios';

const axiosBlob = axios.create({
	// Configuration
	baseURL: process.env.BASE_URL,
	// baseURL:"http://localhost:3002",
	timeout: 30000,
	responseType:"blob"	
});

axiosBlob.interceptors.request.use(config => {
	const authToken = localStorage.getItem('authToken');
	if (authToken) {
		config.headers.Authorization = `Bearer ${authToken}`;
	}
	return config;
});


export default axiosBlob;