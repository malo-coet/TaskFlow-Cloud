import { Amplify, Auth } from 'aws-amplify';

// Configuration
export const amplifyConfig = {
  Auth: {
    region: import.meta.env.VITE_AWS_REGION || 'us-east-1',
    userPoolId: import.meta.env.VITE_COGNITO_USER_POOL_ID || '',
    userPoolWebClientId: import.meta.env.VITE_COGNITO_CLIENT_ID || '',
    identityPoolId: import.meta.env.VITE_COGNITO_IDENTITY_POOL_ID || '',
  },
};

// Initialize
Amplify.configure(amplifyConfig);

/**
 * Sign up user
 */
export async function signUp(email: string, password: string) {
  try {
    const result = await Auth.signUp({
      username: email,
      password: password,
      attributes: {
        email: email,
      },
    });
    return result;
  } catch (error) {
    console.error('Sign up error:', error);
    throw error;
  }
}

/**
 * Confirm sign up (email verification)
 */
export async function confirmSignUp(email: string, code: string) {
  try {
    const result = await Auth.confirmSignUp(email, code);
    return result;
  } catch (error) {
    console.error('Confirm sign up error:', error);
    throw error;
  }
}

/**
 * Sign in user
 */
export async function signIn(email: string, password: string) {
  try {
    const user = await Auth.signIn({
      username: email,
      password: password,
    });
    return user;
  } catch (error) {
    console.error('Sign in error:', error);
    throw error;
  }
}

/**
 * Sign out user
 */
export async function signOut() {
  try {
    await Auth.signOut();
  } catch (error) {
    console.error('Sign out error:', error);
    throw error;
  }
}

/**
 * Get current user
 */
export async function getCurrentUser() {
  try {
    const user = await Auth.currentAuthenticatedUser();
    return user;
  } catch (error) {
    console.log('No user logged in');
    return null;
  }
}

/**
 * Get JWT token for API calls
 */
export async function getJWTToken(): Promise<string | null> {
  try {
    const session = await Auth.currentSession();
    return session.idToken.jwtToken;
  } catch (error) {
    console.error('Failed to get JWT:', error);
    return null;
  }
}

/**
 * Refresh JWT token
 */
export async function refreshToken() {
  try {
    const session = await Auth.currentSession();
    return session.idToken.jwtToken;
  } catch (error) {
    console.error('Token refresh error:', error);
    throw error;
  }
}

/**
 * Forgot password
 */
export async function forgotPassword(email: string) {
  try {
    const result = await Auth.forgotPassword(email);
    return result;
  } catch (error) {
    console.error('Forgot password error:', error);
    throw error;
  }
}

/**
 * Reset password
 */
export async function resetPassword(
  email: string,
  code: string,
  newPassword: string
) {
  try {
    const result = await Auth.forgotPasswordSubmit(email, code, newPassword);
    return result;
  } catch (error) {
    console.error('Reset password error:', error);
    throw error;
  }
}

