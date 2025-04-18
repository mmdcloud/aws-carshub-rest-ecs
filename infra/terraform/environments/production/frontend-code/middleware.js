import { NextResponse } from 'next/server';
import jwt from 'jsonwebtoken'; // Optional, if you're verifying JWT tokens

export function middleware(req) {
  // validate the token (assuming a JWT token in this case)
  try {
    console.log("inhere");
    var token = localStorage.getItem("authToken");
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    // If the token is invalid, redirect to login
    return NextResponse.redirect(new URL('/auth/login', req.url));
  }

  // If everything is fine, continue to the requested page
  return NextResponse.next();
}
