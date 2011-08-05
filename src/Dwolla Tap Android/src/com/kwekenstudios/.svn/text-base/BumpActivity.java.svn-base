package com.kwekenstudios;

import java.util.*;
import java.io.ByteArrayInputStream;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.widget.EditText;
import android.view.*;
import android.os.AsyncTask;
import android.widget.ProgressBar;
import android.content.SharedPreferences;

import android.widget.TextView;
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

import com.bumptech.bumpapi.BumpAPI;
import com.bumptech.bumpapi.BumpAPIListener;
import com.bumptech.bumpapi.BumpConnection;
import com.bumptech.bumpapi.BumpDisconnectReason;
import com.bumptech.bumpapi.BumpConnectFailedReason;



public class BumpActivity extends Activity implements BumpAPIListener {
    public static final String PREFS_NAME = "DwollaTapPreferencesForImportantStuff";
    private String _dwollaId;
    private String _name;
    private ProgressBar _progress;
    private BumpConnection conn;
    private EditText _amount;

    private final Handler handler = new Handler();

    @Override
    public void onCreate(Bundle savedInstanceState) {
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bump);

        Bundle bundle = this.getIntent().getExtras();
        _name = bundle.getString("name");
        _dwollaId = bundle.getString("dwollaId");
        _amount = (EditText) findViewById(R.id.amount);
    }

    @Override
	public void onStop() {
		if (conn != null)
			conn.disconnect();

		super.onStop();
	}

    @Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == RESULT_OK) {
			conn = (BumpConnection) data.getParcelableExtra(BumpAPI.EXTRA_CONNECTION);
			conn.setListener(this, handler);

            String collection = "request|" + _dwollaId + "|" + _name;
            //Float amount = Float.parseFloat(_amount.getText().toString().trim());
            //if(_amount.getText().toString().trim().length() > 0) {
            //    collection += "|" + amount.toString();
            //}

            try {
			    conn.send(collection.getBytes("UTF-8"));
		    } catch (Exception e) {
		    }
		} else {
			//BumpConnectFailedReason reason = (BumpConnectFailedReason)data.getSerializableExtra(BumpAPI.EXTRA_REASON);
		}
	}

    private String getPassword() {
       SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
       return settings.getString("email", "");
    }

    private String getEmail() {
       SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
       return settings.getString("password", "");
    }

    public void bumpButtonClick(View v) {
        Intent bump = new Intent(this, BumpAPI.class);
		bump.putExtra(BumpAPI.EXTRA_API_KEY, "c2286aa7158e4af893cd857195fa9dfc");
		startActivityForResult(bump, 0);
    }

    public void logoutButtonClick(View v) {
        SharedPreferences settings = getSharedPreferences(Globals.PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("password", "");
        editor.commit();

        finish();
    }

	public void bumpDisconnect(BumpDisconnectReason reason) {
		switch (reason) {
			case END_OTHER_USER_QUIT:
				Log.e("Bump Chat", "Failed to parse incoming data");
				break;
			case END_OTHER_USER_LOST:
				//updateChat("--- " + conn.getOtherUserName() + " LOST ---");
				break;
		}

		//connect.setEnabled(true);
		//send.setEnabled(false);
	}

	public void bumpDataReceived(byte[] chunk) {
		try {
            ByteArrayInputStream stream = new ByteArrayInputStream(chunk);
            String list = new String(chunk);

            Log.e("Test", list);

			String data = new String(chunk, "UTF-8");

            Log.e("Test2", data);

            String[] collection = data.split("|");

            if (collection[1] == "request") {

            }

		} catch (Exception e) {
			Log.e("Bump Chat", "Failed to parse incoming data");
			e.printStackTrace();
		}
	}


    private class SendTask extends AsyncTask<String, Void, JSONObject> {
        protected JSONObject doInBackground(String... credentials) {
            JSONObject str = null;
            JSONObject params = new JSONObject();
            try {
                params.put("APIUsername",Globals.DWOLLA_API_USERNAME);
                params.put("APIPassword",Globals.DWOLLA_API_PASSWORD);
                params.put("EmailAddress", credentials[0]);
                params.put("Password", credentials[1]);
                params.put("PIN", credentials[2]);
                params.put("DestinationID", credentials[3]);
                params.put("Amount", credentials[4]);
                params.put("Notes", "Tap Tap!");
                params.put("FundsSource", "Balance");

                StringEntity se = new StringEntity(params.toString());
                se.setContentEncoding(new BasicHeader(HTTP.CONTENT_TYPE, "application/json"));


                HttpClient hc = new DefaultHttpClient();
                HttpPost post = new HttpPost(Globals.DWOLLA_REST_URL + "send");
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
        }
    }
}
