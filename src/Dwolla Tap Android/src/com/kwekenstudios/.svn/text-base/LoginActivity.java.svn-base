package com.kwekenstudios;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.*;
import android.widget.TextView;
import android.os.AsyncTask;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.content.Intent;
import android.content.SharedPreferences;

import org.json.JSONException;
import org.json.JSONObject;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.util.EntityUtils;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHeader;
import org.apache.http.protocol.HTTP;

public class LoginActivity extends Activity {
    private TextView _errorLabel;
    private EditText _usernameText;
    private EditText _passwordText;
    private ProgressBar _progressBar;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        _errorLabel = (TextView) findViewById(R.id.error);
        _usernameText = (EditText) findViewById(R.id.username);
        _passwordText = (EditText) findViewById(R.id.password);
        _progressBar = (ProgressBar) findViewById(R.id.progress);

       SharedPreferences settings = getSharedPreferences(Globals.PREFS_NAME, 0);
       _usernameText.setText(settings.getString("email", ""));
       _passwordText.setText(settings.getString("password", ""));

       if(_usernameText.getText().toString().trim().compareTo("") != 0 && _passwordText.getText().toString().compareTo("") != 0) {
            signInButtonClick(this.getCurrentFocus());
       }
    }

    public void signInButtonClick(View v) {
        String[] credentials = new String[2];
        credentials[0] = _usernameText.getText().toString().trim();
        credentials[1] = _passwordText.getText().toString().trim();


        if(credentials[0].compareTo("") != 0 && credentials[1].compareTo("") != 0) {
            _progressBar.setVisibility(View.VISIBLE);

            new AuthenticateTask().execute(credentials);
        } else {
            _errorLabel.setText(Globals.ERROR_NEED_USERNAME_PASSWORD);
        }
    }

    private void setPreferences(String email, String password) {
      SharedPreferences settings = getSharedPreferences(Globals.PREFS_NAME, 0);
      SharedPreferences.Editor editor = settings.edit();
      editor.putString("email", email);
      editor.putString("password", password);

      // Commit the edits!
      editor.commit();
    }

    private class AuthenticateTask extends AsyncTask<String, Void, JSONObject> {
        protected JSONObject doInBackground(String... credentials) {
            JSONObject str = null;
            JSONObject params = new JSONObject();
            try {
                params.put("APIUsername",Globals.DWOLLA_API_USERNAME);
                params.put("APIPassword",Globals.DWOLLA_API_PASSWORD);
                params.put("AccountIdentifier", credentials[0]);
                params.put("Password", credentials[1]);

                StringEntity se = new StringEntity(params.toString());
                se.setContentEncoding(new BasicHeader(HTTP.CONTENT_TYPE, "application/json"));


                HttpClient hc = new DefaultHttpClient();
                HttpPost post = new HttpPost(Globals.DWOLLA_REST_URL + "account_information");
                post.setHeader("Content-Type","application/json");
                post.setEntity(se);


                HttpResponse rp = hc.execute(post);

                try{
                    str = new JSONObject(EntityUtils.toString(rp.getEntity()));
                }catch(JSONException e) {
                   return null;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            return str;
        }

        protected void onPostExecute(JSONObject result) {
            if (result != null) {
                try{
                   JSONObject account_information = new JSONObject(result.getString("AccountInformationResult"));
                    if(account_information != null) {
                        Bundle bundle = new Bundle();
                        bundle.putString("name", account_information.getString("Name"));
                        bundle.putString("dwollaId", account_information.getString("Id"));

                        setPreferences(_usernameText.getText().toString(), _passwordText.getText().toString());

                        Intent myIntent = new Intent(LoginActivity.this, BumpActivity.class);
                        myIntent.putExtras(bundle);
                        startActivityForResult(myIntent, 0);
                    }
                } catch(Exception e) {
                    _errorLabel.setText(Globals.ERROR_INVALID_CREDS);
                }
            } else {
                _errorLabel.setText(Globals.ERROR_UNEXPECTED);
            }
            _passwordText.setText("");
            _progressBar.setVisibility(View.INVISIBLE);
        }
    }
}
